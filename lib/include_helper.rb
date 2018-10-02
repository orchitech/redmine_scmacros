class IncludeHelper

  # Link structure is as follows below. {} braces denotes optional parts, if they're not present, a default value is assumed.
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
end