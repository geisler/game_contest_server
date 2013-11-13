def expect_same_minute(datetime_1, datetime_2)
  expect(datetime_1.strftime("%F %R")).to eq(datetime_2.strftime("%F %R"))
end
