# frozen_string_literal: true

export_default :LineReader

Core = import('./core')

# a stream that can read single lines from another stream
class LineReader
  # Initializes the line reader with a source and optional line separator
  # @param source [Stream] source stream
  # @param sep [String] line separator
  def initialize(source = nil, sep = $/)
    @source = source
    if source
      source.on(:data) { |data| push(data) }
      source.on(:close) { close }
      source.on(:error) { |err| error(err) }
    end
    @read_buffer = +''
    @separator = sep
    @separator_size = sep.bytesize
  end

  # Pushes data into the read buffer and emits lines
  # @param data [String] data to be read
  # @return [void]
  def push(data)
    @read_buffer << data
    emit_lines
  end

  # Emits lines from the read buffer
  # @return [void]
  def emit_lines
    while (line = gets)
      @lines_promise.resolve(line)
    end
  end

  # Returns a line sliced from the read buffer
  # @return [String] line
  def gets
    idx = @read_buffer.index(@separator)
    idx && @read_buffer.slice!(0, idx + @separator_size)
  end

  # Returns a async generator of lines
  # @return [Promise] line generator
  def lines
    Core::Async.generator do |p|
      @lines_promise = p
    end
  end

  # Iterates asynchronously over lines received
  # @return [void]
  def each_line(&block)
    lines.each(&block)
  end

  # Closes the stream and cancels any pending reads
  # @param [void]
  def close
    @lines_promise&.stop
  end

  # handles error generated by source
  # @param err [Exception] raised error
  # @param [void]
  def error(err)
    return unless @lines_promise

    @lines_promise.stop
    @lines_promise.error(err)
  end
end