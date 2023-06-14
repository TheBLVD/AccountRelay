# frozen_string_literal: true

class DataSignature
  include JsonldHelper

  CONTEXT = 'https://w3id.org/identity/v1'

  def initialize(json)
    @json = json.with_indifferent_access
  end

  def perform
    @digest = create_digest
    Rails.logger.debug('>>>')
    Rails.logger.debug @digest
    @digest
  end

  private

  def create_digest
    Digest::SHA256.base64digest(@json.to_s)
  end

  def hash(obj)
    Digest::SHA256.hexdigest(canonicalize(obj))
  end
end
