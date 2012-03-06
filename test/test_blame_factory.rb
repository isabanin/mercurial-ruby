require File.dirname(__FILE__) + '/helper'

describe Mercurial::BlameFactory do
  
  before do
    @repository = Mercurial::Repository.open(Fixtures.test_repo)
    @factory = @repository.blames
  end
  
  it "should find blame by filename" do
    blame = @factory.for_path('LICENSE4.txt')
    blame.must_be_kind_of(Mercurial::Blame)
    blame.contents.must_equal blame_sample
  end
  
  it "should raise exception when file not found" do
    lambda{ @factory.for_path('somecrap') }.must_raise Mercurial::CommandError
  end
  
private

  def blame_sample
    %Q[ilya bf6386c0a0cc: 1: Copyright (c) 2008 Josh Nichols
ilya bf6386c0a0cc: 2: 
ilya 825fd6032c3b: 3: Changed!
ilya 825fd6032c3b: 4: 
ilya bf6386c0a0cc: 3: Permission is hereby granted, free of charge, to any person obtaining
ilya bf6386c0a0cc: 4: a copy of this software and associated documentation files (the
ilya bf6386c0a0cc: 5: "Software"), to deal in the Software without restriction, including
ilya bf6386c0a0cc: 6: without limitation the rights to use, copy, modify, merge, publish,
ilya bf6386c0a0cc: 7: distribute, sublicense, and/or sell copies of the Software, and to
ilya bf6386c0a0cc: 8: permit persons to whom the Software is furnished to do so, subject to
ilya bf6386c0a0cc: 9: the following conditions:
ilya bf6386c0a0cc:10: 
ilya bf6386c0a0cc:11: The above copyright notice and this permission notice shall be
ilya bf6386c0a0cc:12: included in all copies or substantial portions of the Software.
ilya bf6386c0a0cc:13: 
ilya 6157254a4423:14: THE SOFTWARE IS PROVIDED "AS IS", WITHOUROM, OUT OF OR IN CONNECTION
ilya bf6386c0a0cc:20: WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]
  end
  
end