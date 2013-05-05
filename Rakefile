require "yaml"

NAME_PATTERN = /^(?<dir>.+\/)*(?<date>\d+-\d+-\d+)-(?<title>.*)(?<ext>\.[^.]+)$/

desc "Rename post"
task :rename_post, :post, :new_title do |t, args|
  raise "### You haven't set anything up yet. First run `rake install` to set up an Octopress theme." unless File.directory?(source_dir)

  args.with_defaults(post: nil, new_title: '')
  raise "post is not provided." if args.post.nil?
  raise "post cannot be found." unless File.exists?(args.post)

  new_title = args.new_title.strip
  new_title = YAML.load_file(args.post)['title'] if new_title.empty?
  new_title = new_title.to_url

  name_parts = args.post.match NAME_PATTERN
  abort("Not a post") if name_parts.nil?

  new_name = File.join(name_parts[:dir], "#{name_parts[:date]}-#{new_title}#{name_parts[:ext]}")

  if args.post == new_name
    puts "No need to rename"
  else
    abort("Post #{new_name} existed!") if File.exists?(new_name)

    puts "Renaming #{args.post}"
    puts "To #{new_name}"
    FileUtils.move args.post, new_name

    attachment_dir = "#{source_dir}/attachments/#{name_parts[:date]}-#{name_parts[:title]}"

    if File.exists?(attachment_dir)
      puts "Attachment found, renmaing..."
      FileUtils.move attachment_dir, "#{source_dir}/attachments/#{name_parts[:date]}-#{new_title}"
    end
  end
end

namespace :attachment do
  desc "Create attachment folder for post"
  task :create, :post do |t, args|
    args.with_defaults(post: '')
    name_parts = args.post.match NAME_PATTERN
    abort("Not a post") if name_parts.nil?

    attachment_dir = "#{source_dir}/attachments/#{name_parts[:date]}-#{name_parts[:title]}"

    FileUtils.mkdir_p attachment_dir

    sh %Q{open "#{attachment_dir}"}
  end

  desc "Delete all attachments for post"
  task :delete, :post do |t, args|
    args.with_defaults(post: '')
    name_parts = args.post.match NAME_PATTERN
    abort("Not a post") if name_parts.nil?

    attachment_dir = "#{source_dir}/attachments/#{name_parts[:date]}-#{name_parts[:title]}"
    abort("No attachments") unless File.exists?(attachment_dir)

    FileUtils.rm_rf attachment_dir if ask("Sure to delete the folder #{attachment_dir}",%w{y n}) == 'y'
  end

  desc "Delete all empty attachment folders"
  task :clean do
    Dir.glob("#{source_dir}/attachments/*") do |dir|
      if Dir.glob(File.join(dir, '*')).to_a.empty?
        puts "Removing empty attachment folder: #{File.basename(dir)}"
        FileUtils.rm_r(dir)
      end
    end
  end

  desc "Open attachment folder"
  task :open, :post do |t, args|
    args.with_defaults(post: '')
    name_parts = args.post.match NAME_PATTERN
    abort("Not a post") if name_parts.nil?

    attachment_dir = "#{source_dir}/attachments/#{name_parts[:date]}-#{name_parts[:title]}"
    sh %Q{open "#{attachment_dir}"}
  end
end