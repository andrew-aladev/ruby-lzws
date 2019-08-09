# Ruby bindings for lzws library

[![Travis build status](https://travis-ci.org/andrew-aladev/ruby-lzws.svg?branch=master)](https://travis-ci.org/andrew-aladev/ruby-lzws)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/andrew-aladev/ruby-lzws?branch=master&svg=true)](https://ci.appveyor.com/project/andrew-aladev/ruby-lzws/branch/master)

See [lzws library](https://github.com/andrew-aladev/lzws).

## Installation

Please install lzws library first.

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
```

You can create and read `tar.Z` archives with `minitar` for example.
LZWS is fully compatible with UNIX compress (with default options).

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

Each API supports additional options, please read lzws docs for more info.

###### Compressor

```
:max_code_bit_length
```

Values: 9 - 16, default value: 16.

```
:block_mode
```

Values: true/false, default value: true.

```
:buffer_length
```

Values: 0, 2 - infinity, default value: 0.
0 means automatic buffer length selection.
1 byte is not enough, 2 bytes is minimal buffer length.

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

###### Decompressor

```
:buffer_length
:without_magic_header
:msb
:unaligned_bit_groups
:quiet
```

Values are the same.

Example:

```ruby
require "lzws"

data = LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT", :msb => true
puts LZWS::String.decompress(data, :msb => true)
```

###### Content-Encoding: compress

```ruby
require "lzws"
require "sinatra"

get "/" do
  headers["Content-Encoding"] = "compress"
  LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT"
end
```

## Docs

###### String

```
::compress(source, options = {})
```

Compress source string (with options).

```
::decompress(source, options = {})
```

Decompress source string (with options).

###### File

```
::compress(source, destination, options = {})
```

Compress source file path to destination file path (with options).

```
::decompress(source, destination, options = {})
```

Decompress source file path to destination file path (with options).

###### Stream::Writer

Its behaviour is similar to builtin [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipWriter.html).

```
::open(file_path, options = {}, :external_encoding => nil, :transcode_options => {}, &block)
```

Open file path and create stream writer (with options) associated with opened file.
Data will be transcoded to `:external_encoding` using `:transcode_options` before writing.

```
::new(destination_io, options = {}, :external_encoding => nil, :transcode_options => {})
```

Create stream writer (with options) associated with destination io.
Data will be transcoded to `:external_encoding` using `:transcode_options` before writing.

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

See [`IO`](https://ruby-doc.org/core-2.6.3/IO.html) docs.

```
#write(*objects)
#flush
#rewind
#close
#closed?
```

See [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

```
#write_nonblock(object, *options)
#flush_nonblock(*options)
#rewind_nonblock(*options)
#close_nonblock(*options)
```

Special asynchronous methods that are missing in `Zlib::GzipWriter`.
`rewind` wants to do `close`, `close` wants to do `flush`, `flush` want to `write` something.
So it is possible to have asynchronous variants for all synchronous methods.
Behaviour is the same as `IO#write_nonblock` method.

```
#<<(object)
#print(*objects)
#printf(*args)
#putc(object, encoding: ::Encoding::BINARY)
#puts(*objects)
```

Typical helpers, see [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipWriter.html) docs.

###### Stream::Reader

Its behaviour is similar to builtin [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipReader.html).

```
::open(file_path, options = {}, :external_encoding => nil, :internal_encoding => nil, :transcode_options => {}, &block)
```

Open file path and create stream reader (with options) associated with opened file.
Data will be forced encoded to `:external_encoding` and transcoded to `:external_encoding` using `:transcode_options` after reading.

```
::new(source_io, options = {}, :external_encoding => nil, :internal_encoding => nil, :transcode_options => {})
```

Create stream reader (with options) associated with source io.
Data will be forced encoded to `:external_encoding` and transcoded to `:external_encoding` using `:transcode_options` after reading.

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

See [`IO`](https://ruby-doc.org/core-2.6.3/IO.html) docs.

```
#lineno
#lineno=
#read(bytes_to_read = nil, out_buffer = nil)
#eof?
#rewind
#close
#closed?
```

See [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

```
#readpartial(bytes_to_read = nil, out_buffer = nil)
#read_nonblock(bytes_to_read, out_buffer = nil, *options)
```

See [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

```
#getbyte
#each_byte(&block)
#readbyte
#ungetbyte(byte)

#getc
#readchar
#each_char(&block)
#ungetc(char)

#gets(separator = $OUTPUT_RECORD_SEPARATOR, limit = nil)
#readline
#readlines
#each(&block)
#each_line(&block)
#ungetline(line)
```

Typical helpers, see [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipReader.html) docs.

## License

MIT license, see LICENSE and AUTHORS.
