require 'helper'

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
    %Q[ilya bf6386c0a0cc: Copyright (c) 2008 Josh Nichols
ilya bf6386c0a0cc: 
ilya 825fd6032c3b: Changed!
ilya 825fd6032c3b: 
ilya bf6386c0a0cc: Permission is hereby granted, free of charge, to any person obtaining
ilya bf6386c0a0cc: a copy of this software and associated documentation files (the
ilya bf6386c0a0cc: "Software"), to deal in the Software without restriction, including
ilya bf6386c0a0cc: without limitation the rights to use, copy, modify, merge, publish,
ilya bf6386c0a0cc: distribute, sublicense, and/or sell copies of the Software, and to
ilya bf6386c0a0cc: permit persons to whom the Software is furnished to do so, subject to
ilya bf6386c0a0cc: the following conditions:
ilya bf6386c0a0cc: 
ilya bf6386c0a0cc: The above copyright notice and this permission notice shall be
ilya bf6386c0a0cc: included in all copies or substantial portions of the Software.
ilya bf6386c0a0cc: 
ilya 6157254a4423: THE SOFTWARE IS PROVIDED "AS IS", WITHOUROM, OUT OF OR IN CONNECTION
ilya bf6386c0a0cc: WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]
  end
  
end