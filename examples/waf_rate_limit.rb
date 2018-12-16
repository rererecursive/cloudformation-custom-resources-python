# CFNDSL

Resource('RateLimitRule') {
    Type 'Custom::WAFRateLimit'
    Property('ServiceToken', FnGetAtt('WAFRateLimitFunction', 'Arn'))
    Property('EnvironmentName', Ref('EnvironmentName'))
    Property('Region', Ref("AWS::Region"))
    Property('Rate', 5000)
    Property('Negated', true)
    Property('Action', 'BLOCK')
    Property('IPSet', waf_ip_set(ip_blocks, ['rate_limited']))
    Property('WebACLId', Ref('WebACL'))
    Property('Priority', 2)
}

Resource('WAFRateLimitFunction') {
    Type 'AWS::Lambda::Function'
    Property('Code', './waf_rate_limit/')
    Property('Handler', 'handler.lambda_handler')
    Property('Runtime', 'python3.6')
    Property('Timeout', 60)
    Property('Role', FnGetAtt('WAFRole', 'Arn'))
}

Resource("WAFRole") {
    Type 'AWS::IAM::Role'
    Property('AssumeRolePolicyDocument', {
      Statement: [
        Effect: 'Allow',
        Principal: { Service: [ 'lambda.amazonaws.com' ] },
        Action: [ 'sts:AssumeRole' ]
      ]
    })
    Property('Path','/')
    Property('Policies', Policies.new.get_policies('waf'))
}
