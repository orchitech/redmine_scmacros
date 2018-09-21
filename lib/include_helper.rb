class IncludeHelper
  def self.parse_url_path(path)
    return path.match(/\/([^\/]+)\/repository\/(?:(?:([^\/]+)?\/)?(?:revisions\/([^\/]+)\/)?)?entry\/(.+)/).captures
  end
end