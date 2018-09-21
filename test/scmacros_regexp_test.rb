require "minitest/autorun"
require "../lib/include_helper"
class RegexpTest < Minitest::Test

  def setup
  end

  def test_correct
    testcases = [
        ['/projects/other-test/repository/entry/test-page.asciidoc', ['other-test', nil, nil, 'test-page.asciidoc']],
        ['/projects/other-test/repository/revisions/master/entry/othermarkdown.md', ['other-test', nil, 'master', 'othermarkdown.md']],
        ['/projects/test/repository/documentation/entry/othermarkdown.md', ['test', 'documentation', nil, 'othermarkdown.md']],
        ['/projects/test/repository/another_repo/revisions/master/entry/testdir/testdir.md', ['test', 'another_repo', 'master', 'testdir/testdir.md']]
    ]

    testcases.each do |test|
      assert_equal(test[1], IncludeHelper::parse_url_path(test[0]))
    end
  end
end
