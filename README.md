# Ruby bindings for lzws library

| Travis | AppVeyor | Cirrus | Circle | Codecov |
| :---:  | :---:    | :---:  | :---:  | :---:   |
| [![Travis test status](https://travis-ci.com/andrew-aladev/ruby-lzws.svg?branch=master)](https://travis-ci.com/andrew-aladev/ruby-lzws) | [![AppVeyor test status](https://ci.appveyor.com/api/projects/status/github/andrew-aladev/ruby-lzws?branch=master&svg=true)](https://ci.appveyor.com/project/andrew-aladev/ruby-lzws/branch/master) | [![Cirrus test status](https://api.cirrus-ci.com/github/andrew-aladev/ruby-lzws.svg?branch=master)](https://cirrus-ci.com/github/andrew-aladev/ruby-lzws) | [![Circle test status](https://circleci.com/gh/andrew-aladev/ruby-lzws/tree/master.svg?style=shield)](https://circleci.com/gh/andrew-aladev/ruby-lzws/tree/master) | [![Codecov](https://codecov.io/gh/andrew-aladev/ruby-lzws/branch/master/graph/badge.svg)](https://codecov.io/gh/andrew-aladev/ruby-lzws) |

See [lzws library](https://github.com/andrew-aladev/lzws).

## Installation

Please install lzws library first, use latest 1.3.0+ version.

```sh
gem install ruby-lzws
```

You can build it from source.

```sh
rake gem
gem install pkg/ruby-lzws-*.gem
```

## Usage

There are simple APIs: `String` and `File`. Also you can use generic streaming API: `Stream::Writer` and `Stream::Reader`.

```ruby
require "lzws"

data = LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT"
puts LZWS::String.decompress(data)

LZWS::File.compress "file.txt", "file.txt.Z"
LZWS::File.decompress "file.txt.Z", "file.txt"

LZWS::Stream::Writer.open("file.txt.Z") { |writer| writer << "TOBEORNOTTOBEORTOBEORNOT" }
puts LZWS::Stream::Reader.open("file.txt.Z") { |reader| reader.read }

writer = LZWS::Stream::Writer.new output_socket
begin
  bytes_written = writer.write_nonblock "TOBEORNOTTOBEORTOBEORNOT"
  # handle "bytes_written"
rescue IO::WaitWritable
  # handle wait
ensure
  writer.close
end

reader = LZWS::Stream::Reader.new input_socket
begin
  puts reader.read_nonblock(512)
rescue IO::WaitReadable
  # handle wait
rescue ::EOFError
  # handle eof
ensure
  reader.close
end
```

You can create and read `tar.Z` archives with `minitar` for example.
LZWS is compatible with UNIX compress (with default options).

```ruby
require "lzws"
require "minitar"

LZWS::Stream::Writer.open "file.tar.Z" do |writer|
  Minitar::Writer.open writer do |tar|
    tar.add_file_simple "file", :data => "TOBEORNOTTOBEORTOBEORNOT"
  end
end

LZWS::Stream::Reader.open "file.tar.Z" do |reader|
  Minitar::Reader.open reader do |tar|
    tar.each_entry do |entry|
      puts entry.name
      puts entry.read
    end
  end
end
```

## Options

Each API supports several options:

```
:source_buffer_length
:destination_buffer_length
```

There are internal buffers for compressed and decompressed data.
For example you want to use 1 KB as source buffer length for compressor - please use 256 B as destination buffer length.
You want to use 256 B as source buffer length for decompressor - please use 1 KB as destination buffer length.

Values: 0, 2 - infinity, default value: 0.
0 means automatic buffer length selection.
1 byte is not enough, 2 bytes is minimal buffer length.

```
:max_code_bit_length
```

Values: `LZWS::Option::LOWEST_MAX_CODE_BIT_LENGTH` - `LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH`, default value: `LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH`.

```
:block_mode
```

Values: true/false, default value: true.

```
:without_magic_header
```

Values: true/false, default value: false.

```
:msb
```

Values: true/false, default value: false.

```
:unaligned_bit_groups
```

Values: true/false, default value: false.

```
:quiet
```

Values: true/false, default value: false.
Disables lzws library logging.

Please read lzws docs for more info about options.

Possible compressor options:
```
:source_buffer_length
:destination_buffer_length
:max_code_bit_length
:block_mode
:without_magic_header
:msb
:unaligned_bit_groups
:quiet
```

Possible decompressor options:
```
:source_buffer_length
:destination_buffer_length
:without_magic_header
:msb
:unaligned_bit_groups
:quiet
```

Example:

```ruby
require "lzws"

data = LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT", :msb => true
puts LZWS::String.decompress(data, :msb => true)
```

Default options are compatible with UNIX compress (`Content-Encoding: compress`):

```ruby
require "lzws"
require "sinatra"

get "/" do
  headers["Content-Encoding"] = "compress"
  LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT"
end
```

Please read more about compatibility in lzws docs.

## String

String maintains destination buffer only, so it accepts `destination_buffer_length` option only.

```
::compress(source, options = {})
::decompress(source, options = {})
```

`source` is a source string.

## File

File maintains both source and destination buffers, it accepts both `source_buffer_length` and `destination_buffer_length` options.

```
::compress(source, destination, options = {})
::decompress(source, destination, options = {})
```

`source` and `destination` are file pathes.

## Stream::Writer

Its behaviour is similar to builtin [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib-2.7.0/libdoc/zlib/rdoc/Zlib/GzipWriter.html).

Writer maintains destination buffer only, so it accepts `destination_buffer_length` option only.

```
::open(file_path, options = {}, :external_encoding => nil, :transcode_options => {}, &block)
```

Open file path and create stream writer associated with opened file.
Data will be transcoded to `:external_encoding` using `:transcode_options` before compressing.

```
::new(destination_io, options = {}, :external_encoding => nil, :transcode_options => {})
```

Create stream writer associated with destination io.
Data will be transcoded to `:external_encoding` using `:transcode_options` before compressing.

```
#set_encoding(external_encoding, nil, transcode_options)
```

Set another encodings, `nil` is just for compatibility with `IO`.

```
#io
#to_io
#stat
#external_encoding
#transcode_options
#pos
#tell
```

See [`IO`](https://ruby-doc.org/core-2.7.0/IO.html) docs.

```
#write(*objects)
#flush
#rewind
#close
#closed?
```

See [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib-2.7.0/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

```
#write_nonblock(object, *options)
#flush_nonblock(*options)
#rewind_nonblock(*options)
#close_nonblock(*options)
```

Special asynchronous methods missing in `Zlib::GzipWriter`.
`rewind` wants to `close`, `close` wants to `write` something and `flush`, `flush` want to `write` something.
So it is possible to have asynchronous variants for these synchronous methods.
Behaviour is the same as `IO#write_nonblock` method.

```
#<<(object)
#print(*objects)
#printf(*args)
#putc(object, encoding: ::Encoding::BINARY)
#puts(*objects)
```

Typical helpers, see [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib-2.7.0/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

## Stream::Reader

Its behaviour is similar to builtin [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.7.0/libdoc/zlib/rdoc/Zlib/GzipReader.html).

Reader maintains both source and destination buffers, it accepts both `source_buffer_length` and `destination_buffer_length` options.

```
::open(file_path, options = {}, :external_encoding => nil, :internal_encoding => nil, :transcode_options => {}, &block)
```

Open file path and create stream reader associated with opened file.
Data will be force encoded to `:external_encoding` and transcoded to `:internal_encoding` using `:transcode_options` after decompressing.

```
::new(source_io, options = {}, :external_encoding => nil, :internal_encoding => nil, :transcode_options => {})
```

Create stream reader associated with source io.
Data will be force encoded to `:external_encoding` and transcoded to `:internal_encoding` using `:transcode_options` after decompressing.

```
#set_encoding(external_encoding, internal_encoding, transcode_options)
```

Set another encodings.

```
#io
#to_io
#stat
#external_encoding
#internal_encoding
#transcode_options
#pos
#tell
```

See [`IO`](https://ruby-doc.org/core-2.7.0/IO.html) docs.

```
#read(bytes_to_read = nil, out_buffer = nil)
#eof?
#rewind
#close
#closed?
```

See [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.7.0/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

```
#readpartial(bytes_to_read = nil, out_buffer = nil)
#read_nonblock(bytes_to_read, out_buffer = nil, *options)
```

See [`IO`](https://ruby-doc.org/core-2.7.0/IO.html) docs.

```
#getbyte
#each_byte(&block)
#readbyte
#ungetbyte(byte)

#getc
#readchar
#each_char(&block)
#ungetc(char)

#lineno
#lineno=
#gets(separator = $OUTPUT_RECORD_SEPARATOR, limit = nil)
#readline
#readlines
#each(&block)
#each_line(&block)
#ungetline(line)
```

Typical helpers, see [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.7.0/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

## CI

See universal test script [scripts/ci_test.sh](scripts/ci_test.sh) for CI.
Please visit [scripts/test-images](scripts/test-images).
You can run this test script using many native and cross images.

Cirrus CI uses `x86_64-pc-linux-gnu` image, Circle CI - `x86_64-gentoo-linux-musl` image.

## License

MIT license, see LICENSE and AUTHORS.
