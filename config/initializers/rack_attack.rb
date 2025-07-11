class Rack::Attack
  safelist('allow-localhost') do |req|
    '127.0.0.1' == req.ip || '::1' == req.ip
  end

  throttle('logins/ip', limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == '/api/v1/auth/login' && req.post?
  end

  throttle('business_logins/ip', limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == '/api/v1/business_auth/login' && req.post?
  end

  throttle('signups/ip', limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == '/api/v1/auth/signup' && req.post?
  end

  throttle('business_signups/ip', limit: 3, period: 60.seconds) do |req|
    req.ip if req.path == '/api/v1/business_auth/signup' && req.post?
  end

  self.throttled_response = lambda do |env|
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'application/json',
        'Retry-After' => retry_after.to_s
      },
      [
        {
          success: false,
          error: 'Too many requests. Please try again later.'
        }.to_json
      ]
    ]
  end
end

ActiveSupport::Notifications.subscribe('rack.attack') do |name, start, finish, request_id, req|
  Rails.logger.warn "Throttle match: #{req.env['rack.attack.match_type']} on #{req.path} from IP #{req.ip}"
end