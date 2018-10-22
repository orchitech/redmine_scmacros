require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper')

class RegexpTest < Redmine::HelperTest

  def test_correct_parsing
    testcases = {
        '/projects/other-test/repository/entry/test-page.asciidoc' => ['other-test', nil, nil, 'test-page.asciidoc'],
        '/projects/other-test/repository/revisions/master/entry/othermarkdown.md' => ['other-test', nil, 'master', 'othermarkdown.md'],
        '/projects/test/repository/documentation/entry/othermarkdown.md' => ['test', 'documentation', nil, 'othermarkdown.md'],
        '/projects/test/repository/another_repo/revisions/master/entry/testdir/testdir.md' => ['test', 'another_repo', 'master', 'testdir/testdir.md']
    }

    testcases.each do |path, result|
      assert_equal(result, ScmacrosRepositoryInclude::parse_url_path(path))
    end
  end
end
