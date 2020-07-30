# Base class for common logic shared between any type of LTI Launch. E.g.
# an LtiResourceLinkRequest or LtiDeepLinkingRequest 
class LtiLaunchRequestMessage
  attr_reader :message_type, :payload, :deployment_id, :target_link_uri

  TARGET_LINK_URI_CLAIM = 'https://purl.imsglobal.org/spec/lti/claim/target_link_uri'.freeze
  DEPLOYMENT_ID_CLAIM = 'https://purl.imsglobal.org/spec/lti/claim/deployment_id'.freeze
  MESSAGE_TYPE_CLAIM = 'https://purl.imsglobal.org/spec/lti/claim/message_type'.freeze

  def initialize(payload)
    @payload = payload
    @message_type = payload.fetch(MESSAGE_TYPE_CLAIM)
    @deployment_id = payload.fetch(DEPLOYMENT_ID_CLAIM)
    @target_link_uri = payload.fetch(TARGET_LINK_URI_CLAIM)
  end

end
