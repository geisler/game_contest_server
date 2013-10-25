def expect_required_attribute(attribute)
  assignment = (attribute.to_s + '=').to_sym
  subject.send(assignment, nil)

  should_not be_valid
end
