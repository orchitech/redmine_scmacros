require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
include ERB::Util # textilizable() calls html_escape inside it and currently we need this module to call that

class RegexpTest < Redmine::HelperTest

  self.fixture_path = File.dirname(__FILE__ ) + "/../../../test/fixtures/"

  fixtures :projects, :repositories

  def setup
    User.current = User.find_by_login('admin')
  end

  def test_link_generation
    testcases = {
        'source:some/file' => '<p><a class="source" href="/projects/ecookbook/repository/entry/some/file">source:some/file</a></p>',
        'source:path/to/file.txt@revision' => '<p><a class="source" href="/projects/ecookbook/repository/revisions/revision/entry/path/to/file.txt">source:path/to/file.txt@revision</a></p>'
    }

    @project = Project.find(1)
    testcases.each do |text, result| assert_equal(result, textilizable(text))
    end

  end

  def test_correct_parsing
    testcases = {
        '/projects/other-test/repository/entry/test-page.asciidoc' => ['other-test', nil, nil, 'test-page.asciidoc'],
        '/projects/other-test/repository/revisions/master/entry/othermarkdown.md' => ['other-test', nil, 'master', 'othermarkdown.md'],
        '/projects/test/repository/documentation/entry/othermarkdown.md' => ['test', 'documentation', nil, 'othermarkdown.md'],
        '/projects/test/repository/another_repo/revisions/master/entry/testdir/testdir.md' => ['test', 'another_repo', 'master', 'testdir/testdir.md']
    }

    testcases.each do |path, result|
      assert_equal(result, IncludeHelper::parse_url_path(path))
    end
  end
end
