require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')
include ERB::Util # textilizable() calls html_escape inside it and currently we need this module to call that

# Test, if Redmine's URL to file in repository is formatted as we expect and checks permissions.
class LinkGenerationTest < Redmine::HelperTest

  self.fixture_path = File.dirname(__FILE__ ) + "/../../../../test/fixtures/"
  fixtures :projects, :repositories, :users

  def test_if_redmine_creates_links_with_permission
    User.current = User.find_by_login('admin')
    testcases = {
        'source:some/file' => '<p><a class="source" href="/projects/ecookbook/repository/entry/some/file">source:some/file</a></p>',
        'source:path/to/file.txt@revision' => '<p><a class="source" href="/projects/ecookbook/repository/revisions/revision/entry/path/to/file.txt">source:path/to/file.txt@revision</a></p>'
    }

    @project = Project.find(1)
    testcases.each do |text, result| assert_equal(result, textilizable(text))
    end
  end

  def test_if_redmine_doesnt_create_links_without_permission
    User.current = nil # unauthorized user
    @project = Project.find(2) # not a public project

    testcases = {
        'source:some/file' => '<p>source:some/file</p>',
        'source:path/to/file.txt@revision' => '<p>source:path/to/file.txt@revision</p>'
    }

    testcases.each do |text, result| assert_equal(result, textilizable(text))
    end
  end

end
