def file_contents(filename)
  contents = ''
  File.open(filename) do |f|
    contents = f.readlines(nil)[0]
  end

  contents
end

def expect_same_contents(a, b)
  expect(file_contents(a)).to eq(file_contents(b))
end
