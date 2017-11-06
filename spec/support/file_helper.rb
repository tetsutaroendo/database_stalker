module FileHelper

  def write_file(file_path, content)
    File.open(file_path, 'w') do |f|
      f.puts content
    end
  end

  def clean_up_file(file_path)
    File.delete(file_path) if File.exists?(file_path)
  end
end
