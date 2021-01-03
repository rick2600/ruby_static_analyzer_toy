


def func0
  vuln(from_user) # vuln
end
##############################
def func1
  a = from_user
  vuln(a) # vuln
end
##############################
def func2
  a = from_user
  a = 1
  vuln(a) # safe
end
##############################
def func3
  a = from_user
  if (cond)
    a = 1
  else
    a = 2
  end
  vuln(a) # safe
end
##############################
def func4
  a = from_user
  if (cond)
    a = 1
  end
  vuln(a) # vuln
end
##############################
def func5
  a = from_user
  c = 2
  while(cond)
    c = a
    a = 2
    b = 3
  end
  vuln(c) # vuln
end
