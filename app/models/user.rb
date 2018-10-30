class User < ApplicationRecord
  ADMIN_DOMAIN_WHITELIST = ['bebraven.org']

  devise :cas_authenticatable, :rememberable
  
  before_create :attempt_admin_set, unless: :admin?
  
  private
  
  def attempt_admin_set
    return if email.nil?
    
    domain = email.split('@').last
    self.admin = ADMIN_DOMAIN_WHITELIST.include?(domain)
  end
end
