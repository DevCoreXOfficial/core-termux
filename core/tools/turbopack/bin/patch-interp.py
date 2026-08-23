#!/usr/bin/env python3
"""Patch PT_INTERP in an ELF binary. Supports paths longer than the original."""
import struct, sys, os

ELFCLASS64 = 2
ELFDATA2LSB = 1
PT_INTERP = 3
SHT_PROGBITS = 1
SHT_STRTAB = 3

def align_up(val, alignment):
    return (val + alignment - 1) & ~(alignment - 1)

def patch_interp(path, new_interp):
    data = bytearray(os.path.getsize(path))
    with open(path, 'rb') as f:
        f.readinto(data)

    if data[:4] != b'\x7fELF':
        sys.stderr.write(f"{path}: not an ELF\n")
        return 1
    if data[4] != ELFCLASS64 or data[5] != ELFDATA2LSB:
        sys.stderr.write(f"{path}: only 64-bit LE supported\n")
        return 1

    e_phoff = struct.unpack_from('<Q', data, 32)[0]
    e_phentsize = struct.unpack_from('<H', data, 54)[0]
    e_phnum = struct.unpack_from('<H', data, 56)[0]
    e_shoff = struct.unpack_from('<Q', data, 40)[0]
    e_shentsize = struct.unpack_from('<H', data, 58)[0]
    e_shnum = struct.unpack_from('<H', data, 60)[0]
    e_shstrndx = struct.unpack_from('<H', data, 62)[0]

    interp_idx = None
    for i in range(e_phnum):
        off = e_phoff + i * e_phentsize
        p_type = struct.unpack_from('<I', data, off)[0]
        if p_type == PT_INTERP:
            interp_idx = i
            break

    if interp_idx is None:
        sys.stderr.write(f"{path}: no PT_INTERP\n")
        return 1

    ph_off = e_phoff + interp_idx * e_phentsize
    p_offset = struct.unpack_from('<Q', data, ph_off + 8)[0]
    p_vaddr = struct.unpack_from('<Q', data, ph_off + 16)[0]
    p_filesz = struct.unpack_from('<Q', data, ph_off + 32)[0]

    current = data[p_offset:p_offset + p_filesz].rstrip(b'\x00').decode()
    sys.stderr.write(f"current: {current}\nnew: {new_interp}\n")

    new_data = new_interp.encode() + b'\x00'
    new_filesz = len(new_data)

    if new_filesz <= p_filesz:
        # Fit in place
        data[p_offset:p_offset + p_filesz] = new_data.ljust(p_filesz, b'\x00')
        sys.stderr.write("patched in place\n")
    else:
        # Extend: append to file, update PT_INTERP and .interp section
        old_len = len(data)
        new_offset = align_up(old_len, 8)
        pad = new_offset - old_len
        data.extend(b'\x00' * pad)
        data.extend(new_data)

        struct.pack_into('<Q', data, ph_off + 8, new_offset)
        struct.pack_into('<Q', data, ph_off + 16, new_offset)
        struct.pack_into('<Q', data, ph_off + 32, new_filesz)

        # Update .interp section header
        if e_shstrndx < e_shnum:
            strtab_off = e_shoff + e_shstrndx * e_shentsize
            strs_off = struct.unpack_from('<Q', data, strtab_off + 24)[0]

            for i in range(e_shnum):
                sh_off = e_shoff + i * e_shentsize
                sh_name = struct.unpack_from('<I', data, sh_off)[0]
                end = data.find(b'\x00', strs_off + sh_name)
                name = data[strs_off + sh_name:end].decode('latin-1')

                if name == '.interp':
                    struct.pack_into('<Q', data, sh_off + 24, new_offset)
                    struct.pack_into('<Q', data, sh_off + 32, new_filesz)
                    sys.stderr.write(f"updated .interp section (index {i})\n")
                    break

        sys.stderr.write(f"extended: off {p_offset} -> {new_offset}, sz {p_filesz} -> {new_filesz}\n")

    with open(path, 'wb') as f:
        f.write(data)

    # Restore executable bit
    st = os.stat(path)
    if not st.st_mode & os.X_OK:
        os.chmod(path, st.st_mode | 0o111)

    return 0

if __name__ == '__main__':
    if len(sys.argv) != 3:
        sys.stderr.write(f"Usage: {sys.argv[0]} <binary> <new-interpreter>\n")
        sys.exit(1)
    sys.exit(patch_interp(sys.argv[1], sys.argv[2]))
