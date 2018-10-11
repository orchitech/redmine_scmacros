class IncludeHelper

  # project_name:source:repo_name|path/to/file.txt
  # Parses a hyperlink to a file in repository and return the file's contents in UTF8 encoding and the repo (for testing purposes)
  def self.read_file_from_link(link)
    repo, revision_hash, file_path = IncludeHelper.get_repo_and_file_from_link(link)
    text = repo.cat(file_path, revision_hash)
    return Redmine::CodesetUtil.to_utf8_by_setting(text)
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

  def self.get_repo_and_file_from_link(link)
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

    return repo, revision_hash, file_path
  end

end

