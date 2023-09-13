# encoding: utf-8
#
# Jekyll post attachment generator
# https://github.com/timnew/jekyll-attachments
#
# Version: 0.2
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
    def initialize(site, doc, name)
      @doc = doc
      super(site, @doc.attachment_path, '', name)
    end

    def path
      File.join(@doc.attachment_path, @name)
    end

    def destination(dest)
      path = File.dirname(@doc.destination(dest))
      File.join(path, @name)
    end
  end

  class Site
    def attachment_dir
      @attachment_dir ||= File.join(self.source, self.config.fetch('attachment_dir', 'attachments'))
    end
  end

  class Document
    def attachment_path
      return @attachment_path if @attachment_path
      basename = File.basename path, extname
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
      site.posts.docs.select{|p| p.attachment_exists? }.each do |p|
        Dir.glob(File.join(p.attachment_path, "**", "*"), File::FNM_PATHNAME ) do |file|
          relative_path = file.slice(p.attachment_path.length..-1)
          relative_path.slice!(0) if relative_path[0] == '/'
          attachment = Attachment.new(site, p, relative_path)
          puts "found attachment: #{p.basename} > #{attachment.url}"
          site.static_files << attachment
        end
      end
    end
  end
end
