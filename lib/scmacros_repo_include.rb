# ScmacrosRepositoryInclude
# Copyright (C) 2010 Gregory Romé
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
require 'redmine'
require 'redmine_asciidoc_formatter'
require 'include_helper'

module ScmacrosRepositoryInclude

  # project_name:source:repo_name|path/to/file.txt
  # Parses a hyperlink to a file in repository and return the file's contents in UTF8 encoding.
  def self.read_file_from_link(link)


    path = link.match(/<a class="source" href="(.+)">/)

    if path.nil? # if current user doesn't have permissions to view the repo, the link is not generated.
      raise 'Page not found'
    end   

    project_name, repo_name, revision_hash, file_path = IncludeHelper::parse_url_path(path.captures[0])

    project = Project.visible.find_by_identifier(project_name)

    if repo_name.nil?
      repo = project.repository # no repository implicitly means the current main repository
    else
      repo = project.repositories.detect do |repo| repo.identifier == repo_name # detect checks user's permissions for repo
      end
    end

    text = repo.cat(file_path, revision_hash)
    return Redmine::CodesetUtil.to_utf8_by_setting(text)
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository.\n\n" +
      " \{{repo_include(file_path)}}\n" +
      " \{{repo_include(file_path, rev)}}\n"
    macro :repo_include do |obj, args|
      
      return nil if args.length < 1
      file_path = args[0].strip
      rev ||= args[1].strip if args.length > 1
    
      repo = @project.repository
      return nil unless repo
      
      text = repo.cat(file_path, rev)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)
      
      o = text
      
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository.\n\n" +
      " \{{repo_includewiki(file_path)}}\n"
    macro :repo_includewiki do |obj, args|
      
      return nil if args.length < 1
      file_path = args[0].strip
    
      repo = @project.repository
      return nil unless repo
      
      text = repo.cat(file_path)
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)
      
      o = textilizable(text)
      
      return o
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file from repository as a Markdown.\n\n" +
      " \{{repo_includemd(file_path)}}\n"
    macro :repo_includemd do |obj, args|

      text = ScmacrosRepositoryInclude.read_file_from_link(textilizable(args[0]))
      o = Redmine::WikiFormatting.to_html(:markdown, text)
      o = o.html_safe
      return o
      
    end
  end

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a file containing other include macros from repository as an Asciidoc.\n\n" +
             " \{{repo_includemd(file_path)}}\n"
    macro :repo_includeascii do |obj, args|

      text = ScmacrosRepositoryInclude.read_file_from_link(textilizable(args[0]))
      formatter =  RedmineAsciidocFormatter::WikiFormatting::Formatter.new(text)
      o = formatter.to_html
      o = o.html_safe
      return o
    end
  end

end
