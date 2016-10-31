require 'thread' # to use Queue

class FileUploader
  def initialize(files)
    @files = files
  end

  def upload
    threads = []

    @files.each do |(filename, file_data)|
      threads << Thread.new do
        status = upload_to_s3(filename, file_data)
        results << status
      end
    end

    threads.each(&:join)
  end

  def results
    # Threads share AST, so here might be a race condition (one thread creates Queue,
    # then another one creates it again)
    # To fix: move assignment to #initialize
    @results ||= Queue.new
  end

  def upload_to_s3(filename, file_data)
    # immitate upload
    sleep 0.1
    puts "Uploaded #{filename} to S3"

    "success"
  end
end

# ------ main ------

files = {
  'boots.png' => '*image data*',
  'shirts.png' => '*image data*'
}

expected_count = 2

100.times do
  uploader = FileUploader.new(files)
  uploader.upload

  actual_size = uploader.results.size
  fail("Race condition, size = #{actual_size}") if actual_size != expected_count
end

puts "No race condition this time"
exit(0)
