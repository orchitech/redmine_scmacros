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
#
require 'redmine'
require 'github/markup'
require 'nokogiri'

module ScmacrosRepositoryInclude

  Redmine::WikiFormatting::Macros.register do
    desc "Includes and formats a markup file from repository .\n\n" +
             " \{{repo_include(file_path)}}\n"
    macro :repo_include do |obj, args|

      unless args.length == 1
        raise "Got #{args.length} arguments, only one expected."
      end

      text = ScmacrosRepositoryInclude.read_file_from_html(textilizable(args[0]))
      text = Redmine::CodesetUtil.to_utf8_by_setting(text)
      o = text.html_safe
      return o
    end
  end

  private unless Rails.env == 'test'

  # project_name:source:repo_name|path/to/file.txt
  # Parses a hyperlink to a file in repository and return the file's contents and the repo (for testing purposes)
  def self.read_file_from_html(html)
    repo, revision_hash, file_path = ScmacrosRepositoryInclude.get_repo_and_file_from_html(html)
    text = repo.cat(file_path, revision_hash)
    raise "The entry or revision was not found in the repository" if text.nil?
    return GitHub::Markup.render(file_path, text);

  end

  # Link structure is as follows below. {} braces denote optional parts, if these parts are missing, a default value is assumed.
  # That means the current main repository or the latest revision on current branch.
  # project_name/repository/{repo_name}/{revisions/revision_hash}/entry/file_path
  def self.parse_url_path(path)
    return path.match(
        %r{
      /([^/]+)/ #project_name
      repository/
      (?:
        ([^/]+)?/ #repo_name
      )?
      (?:revisions/
        ([^/]+)/ #revision_hash
      )?
      entry/(.+)$ #file_path
      }x
    ).captures
  end

  def self.get_repo_and_file_from_html(html)

    path = Nokogiri::HTML(html).xpath('//a/@href').map { |link| link.value }
    path = path[0]

    raise "No permissions for viewing this file." if path.nil?

    project_name, repo_name, revision_hash, file_path = ScmacrosRepositoryInclude.parse_url_path(path)
    project = Project.visible.find_by_identifier(project_name)

    if repo_name.nil?
      repo = project.repository # no repository implicitly means the current main repository
    else
      repo = project.repositories.detect do |repo| repo.identifier == repo_name # detect checks user's permissions for repo
      end
    end

    return repo, revision_hash, file_path
  end

end
