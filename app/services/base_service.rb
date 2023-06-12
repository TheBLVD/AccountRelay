# frozen_string_literal: true

class BaseService
  def call(*)
    raise NotImplementedError
  end
end
