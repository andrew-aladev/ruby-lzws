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
Compressor supports `:max_code_bit_length`, `:block_mode`, `buffer_length`, `:without_magic_header`, `:msb`, `:unaligned_bit_groups`, `:quiet`.
Decompressor supports `:buffer_length`, `:without_magic_header`, `:msb`, `:unaligned_bit_groups`, `:quiet`.

```ruby
require "lzws"

data = LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT", :msb => true
puts LZWS::String.decompress(data, :msb => true)
```

You can use `Content-Encoding: compress`.

```ruby
require "lzws"
require "sinatra"

get "/" do
  headers["Content-Encoding"] = "compress"
  LZWS::String.compress "TOBEORNOTTOBEORTOBEORNOT"
end
```

## Docs

`LZWS::String`:

```
::compress(source, options = {})
::decompress(source, options = {})
```

`LZWS::File`:

```
::compress(source, destination, options = {})
::decompress(source, destination, options = {})
```

`LZWS::Stream::Writer` and `LZWS::Stream::Reader`:

```
::open(file_path, *args, &block)
#io
#stat
#external_encoding
#internal_encoding
#pos
#tell
#advise
#set_encoding(*args)
#rewind
#close
#closed?
#to_io
```

`Stream::Writer`:

```
::new(destination_io, options = {}, *args)
#write(*objects)
#flush
#write_nonblock(object, *options)
#flush_nonblock(*options)
#rewind_nonblock(*options)
#close_nonblock(*options)
#<<(object)
#print(*objects)
#printf(*args)
#putc(object, encoding: ::Encoding::BINARY)
#puts(*objects)
```

`Stream::Reader`:

```
::new(source_io, options = {}, *args)
#lineno
#lineno=
#read(bytes_to_read = nil, out_buffer = nil)
#readpartial(bytes_to_read = nil, out_buffer = nil)
#read_nonblock(bytes_to_read, out_buffer = nil, *options)
#eof?
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

`LZWS::Stream::Writer` and `LZWS::Stream::Reader` behaviour is the same as builtin [`Zlib::GzipWriter`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipReader.html), [`Zlib::GzipReader`](https://ruby-doc.org/stdlib-2.6.3/libdoc/zlib/rdoc/Zlib/GzipWriter.html) and [IO](https://ruby-doc.org/core-2.6.3/IO.html).
Please read these method descriptions in builtin ruby doc.

## License

MIT license, see LICENSE and AUTHORS.
