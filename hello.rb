class HelloApp
  def call(env)
      [200, {}, ["Hello World"]]
  end
end
