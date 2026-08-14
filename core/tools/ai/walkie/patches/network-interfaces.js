const events = require('events')
const b4a = require('b4a')
const binding = require('../binding')

module.exports = class NetworkInterfaces extends events.EventEmitter {
  constructor(udx) {
    super()

    this._handle = b4a.alloc(binding.sizeof_udx_napi_interface_event_t)
    this._watching = false
    this._destroying = null
    this.interfaces = []
    try {
      binding.udx_napi_interface_event_init(
        udx._handle,
        this._handle,
        this,
        this._onevent,
        this._onclose
      )
      this.interfaces = binding.udx_napi_interface_event_get_addrs(this._handle)
    } catch (e) {
      this.interfaces = []
    }
  }

  _onclose() {
    this.emit('close')
  }

  _onevent() {
    try {
      this.interfaces = binding.udx_napi_interface_event_get_addrs(this._handle)
    } catch (e) {
      this.interfaces = []
    }
    this.emit('change', this.interfaces)
  }

  watch() {
    if (this._watching) return this
    this._watching = true
    try {
      binding.udx_napi_interface_event_start(this._handle)
    } catch (e) {}
    return this
  }

  unwatch() {
    if (!this._watching) return this
    this._watching = false
    try {
      binding.udx_napi_interface_event_stop(this._handle)
    } catch (e) {}
    return this
  }

  async destroy() {
    if (this._destroying) return this._destroying
    this._destroying = events.once(this, 'close')
    try {
      binding.udx_napi_interface_event_close(this._handle)
    } catch (e) {}
    this.emit('close')
    return this._destroying
  }

  [Symbol.iterator]() {
    return this.interfaces[Symbol.iterator]()
  }
}
