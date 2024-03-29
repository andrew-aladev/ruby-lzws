# Ruby bindings for lzws library

| Github actions | Codecov | Gem  |
| :------------: | :-----: | :--: |
| [![Github Actions test status](https://github.com/andrew-aladev/ruby-lzws/workflows/test/badge.svg?branch=master)](https://github.com/andrew-aladev/ruby-lzws/actions) | [![Codecov](https://codecov.io/gh/andrew-aladev/ruby-lzws/branch/master/graph/badge.svg)](https://codecov.io/gh/andrew-aladev/ruby-lzws) | [![Gem](https://img.shields.io/gem/v/ruby-lzws.svg)](https://rubygems.org/gems/ruby-lzws) |

See [lzws library](https://github.com/andrew-aladev/lzws).

Other bindings: [brotli](https://github.com/andrew-aladev/ruby-brs), [zstd](https://github.com/andrew-aladev/ruby-zstds), [bzip2](https://github.com/andrew-aladev/ruby-bzs).

## Installation

Operating systems: GNU/Linux, FreeBSD, OSX.

Dependencies: [lzws](https://github.com/andrew-aladev/lzws) 1.4.0+ version.

```sh
gem install ruby-lzws
```

You can build it from source.

```sh
rake gem
gem install pkg/ruby-lzws-*.gem
```

You can also use [overlay](https://github.com/andrew-aladev/overlay) for gentoo.

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

You can create and read `tar.Z` archives with [minitar](https://github.com/halostatue/minitar).
LZWS is compatible with [UNIX compress](https://en.wikipedia.org/wiki/Compress) (with default options).

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

You can also use `Content-Encoding: compress` with [sinatra](http://sinatrarb.com):

```ruby
require "lzws"
require "sinatra"

get "/" do
  headers["Content-Encoding"] = "compress"
  LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT"
end
```

All functionality (including streaming) can be used inside multiple threads with [parallel](https://github.com/grosser/parallel).
This code will provide heavy load for your CPU.

```ruby
require "lzws"
require "parallel"

Parallel.each large_datas do |large_data|
  LZWS::String.compress large_data
end
```

# Docs

Please review [rdoc generated docs](https://andrew-aladev.github.io/ruby-lzws).

## Options

| Option                      | Values     | Default  | Description |
|-----------------------------|------------|----------|-------------|
| `source_buffer_length`      | 0, 2 - inf | 0 (auto) | internal buffer length for source data |
| `destination_buffer_length` | 0, 2 - inf | 0 (auto) | internal buffer length for description data |
| `gvl`                       | true/false | false    | enables global VM lock where possible |
| `max_code_bit_length`       | 9 - 16     | 16       | max code bit length |
| `block_mode`                | true/false | true     | enables block mode |
| `without_magic_header`      | true/false | false    | disables magic header |
| `msb`                       | true/false | false    | enables most significant bit mode |
| `unaligned_bit_groups`      | true/false | false    | enables unaligned bit groups |
| `quiet`                     | true/false | false    | disables lzws library logging |

There are internal buffers for compressed and decompressed data.
For example you want to use 1 KB as `source_buffer_length` for compressor - please use 256 B as `destination_buffer_length`.
You want to use 256 B as `source_buffer_length` for decompressor - please use 1 KB as `destination_buffer_length`.

`gvl` is disabled by default, this mode allows running multiple compressors/decompressors in different threads simultaneously.
Please consider enabling `gvl` if you don't want to launch processors in separate threads.
If `gvl` is enabled ruby won't waste time on acquiring/releasing VM lock.

You can also read lzws docs for more info about options.

| Option                | Related constants |
|-----------------------|-------------------|
| `max_code_bit_length` | `LZWS::Option::LOWEST_MAX_CODE_BIT_LENGTH` = 9, `LZWS::Option::BIGGEST_MAX_CODE_BIT_LENGTH` = 16 |

Possible compressor options:
```
:source_buffer_length
:destination_buffer_length
:gvl
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
:gvl
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

Its behaviour is similar to builtin [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipWriter.html).

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

See [`IO`](https://ruby-doc.org/core/IO.html) docs.

```
#write(*objects)
#flush
#rewind
#close
#closed?
```

See [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

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
#putc(object, :encoding => 'ASCII-8BIT')
#puts(*objects)
```

Typical helpers, see [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

## Stream::Reader

Its behaviour is similar to builtin [`Zlib::GzipReader`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipReader.html).

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

See [`IO`](https://ruby-doc.org/core/IO.html) docs.

```
#read(bytes_to_read = nil, out_buffer = nil)
#eof?
#rewind
#close
#closed?
```

See [`Zlib::GzipReader`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

```
#readpartial(bytes_to_read = nil, out_buffer = nil)
#read_nonblock(bytes_to_read, out_buffer = nil, *options)
```

See [`IO`](https://ruby-doc.org/core/IO.html) docs.

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

Typical helpers, see [`Zlib::GzipReader`](https://ruby-doc.org/stdlib/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

## Thread safety

`:gvl` option is disabled by default, you can use bindings effectively in multiple threads.
Please be careful: bindings are not thread safe.
You should lock all shared data between threads.

For example: you should not use same compressor/decompressor inside multiple threads.
Please verify that you are using each processor inside single thread at the same time.

## CI

Please visit [scripts/test-images](scripts/test-images).
See universal test script [scripts/ci_test.sh](scripts/ci_test.sh) for CI.

## License

MIT license, see [LICENSE](LICENSE) and [AUTHORS](AUTHORS).
