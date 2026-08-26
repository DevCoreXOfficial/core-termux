## Package Information

- **Name:** ImageMagick
- **Tags:** images, convert, edit
- **Project:** https://imagemagick.org
- **Source:** https://github.com/ImageMagick/ImageMagick
- **Dependencies:** None required by Core

## What is it?

ImageMagick is a free, open-source software suite for creating, editing, converting, and displaying images. It supports 200+ formats and offers powerful command-line tools and APIs for automation, scripting, and integration across platforms.

Full documentation: https://imagemagick.org

<!-- cli-reference -->

## Binary & CLI Reference

- **Binary:** `magick` (aliases: `convert`)

### `--help` output

```text
Version: ImageMagick 7.1.2-29 Q16-HDRI aarch64 b919b37fd:20260727 https://imagemagick.org
Copyright: (C) 1999 ImageMagick Studio LLC
License: https://imagemagick.org/license/
Features: Cipher DPC HDRI
Delegates (built-in): bzlib cairo djvu fftw fontconfig freetype gslib gvc heic jng jp2 jpeg jxl lcms lqr lzma openexr pangocairo png ps raqm raw rsvg tiff webp x xml zip zlib zstd
Compiler: clang (21.0.0)
Usage: magick tool [ {option} | {image} ... ] {output_image}
Usage: magick [ {option} | {image} ... ] {output_image}
       magick [ {option} | {image} ... ] -script {filename} [ {script_args} ...]

Image Settings:
  -adjoin              join images into a single multi-image file
  -affine matrix       affine transform matrix
  -alpha option        activate, deactivate, reset, or set the alpha channel
  -antialias           remove pixel-aliasing
  -authenticate password
                       decipher image with this password
  -attenuate value     lessen (or intensify) when adding noise to an image
  -background color    background color
  -bias value          add bias when convolving an image
  -black-point-compensation
                       use black point compensation
  -blue-primary point  chromaticity blue primary point
  -bordercolor color   border color
  -caption string      assign a caption to an image
  -clip                clip along the first path from the 8BIM profile
  -clip-mask filename  associate a clip mask with the image
  -clip-path id        clip along a named path from the 8BIM profile
  -colorspace type     alternate image colorspace
  -comment string      annotate image with comment
  -compose operator    set image composite operator
  -compress type       type of pixel compression when writing the image
  -define format:option
                       define one or more image format options
  -delay value         display the next image after pausing
  -density geometry    horizontal and vertical density of the image
  -depth value         image depth
  -direction type      render text right-to-left or left-to-right
  -display server      get image or font from this X server
  -dispose method      layer disposal method
  -dither method       apply error diffusion to image
  -encoding type       text encoding type
  -endian type         endianness (MSB or LSB) of the image
  -family name         render text with this font family
  -features distance   analyze image features (e.g. contrast, correlation)
  -fill color          color to use when filling a graphic primitive
  -filter type         use this filter when resizing an image
  -font name           render text with this font
  -format "string"     output formatted image characteristics
  -fuzz distance       colors within this distance are considered equal
  -gravity type        horizontal and vertical text placement
  -green-primary point chromaticity green primary point
  -illuminant type     reference illuminant
  -intensity method    method to generate an intensity value from a pixel
  -intent type         type of rendering intent when managing the image color
```

