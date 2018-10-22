require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
include ERB::Util # textilizable() calls html_escape inside it and currently we need this module to call that

class LinkGenerationTest < Redmine::HelperTest


  self.fixture_path = File.dirname(__FILE__ ) + "/../../../../test/fixtures/"
  fixtures :projects, :repositories, :users

  def test_if_helper_finds_repo_from_link
    User.current = User.find_by_login('admin')
    @project = Project.find(1)

    testcases = {
        'source:some/file' => @project.repository,
    }

    testcases.each do |text, repo| assert_equal(repo, ScmacrosRepositoryInclude.get_repo_and_file_from_html(textilizable(text))[0])
    end
  end


end
