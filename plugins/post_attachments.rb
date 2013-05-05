# encoding: utf-8
#
# Jekyll post attachment generator
# https://github.com/timnew/jekyll-attachments
#
# Version: 0.1
#
# Copyright (c) 2013 TimNew, http://timnew.github.io
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# A generator that publish post attachments with the post for jekyll sites.
#
# Available _config.yml settings :
# - attachment_dir:        The folder to find post attachments in (default is 'attachments').

module Jekyll

  class Attachment < StaticFile
    def initialize(site, post, name)
      @site = site
      @post = post
      @name = name
    end

    def path
      File.join(@post.attachment_path, @name)
    end

    def destination(dest)
      path = File.dirname(@post.destination(dest))
      File.join(path, @name)
    end
  end

  class Site
    def attachment_dir
      @attachment_dir ||= File.join(self.source, self.config.fetch('attachment_dir', 'attachments'))
    end
  end

  class Post
    attr_reader :name

    def attachment_path
      return @attachment_path if @attachment_path
      extname = File.extname @name
      basename = File.basename @name, extname
      @attachment_path = File.join(@site.attachment_dir, basename)
    end

    def attachment_exists?
      File.exist?(attachment_path)
    end
  end

  # Jekyll hook - the generate method is called by jekyll, and generates all of the category pages.
  class GenerateCategories < Generator
    safe true
    priority :low

    def generate(site)
      site.posts.select{|p| p.attachment_exists? }.each do |p|
        Dir.glob(File.join(p.attachment_path, "**", "*"), File::FNM_PATHNAME ) do |file|
          relative_path = file.slice(p.attachment_path.length..-1)
          relative_path.slice!(0) if relative_path[0] == '/'
          puts "Find attachment: #{p.name} > #{relative_path}"
          site.static_files << Attachment.new(site, p, relative_path)
        end
      end
    end
  end
end

