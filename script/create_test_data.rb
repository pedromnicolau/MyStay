#!/usr/bin/env ruby

require_relative '../config/environment'

# Clear existing test data
Tenant.where(master_code: 'test-tenant').destroy_all

# Create test tenant
tenant = Tenant.create!(
  name: 'Test Tenant',
  master_code: 'test-tenant'
)

# Create test user
user = User.create!(
  tenant_id: tenant.id,
  email: 'test@example.com',
  first_name: 'Test',
  last_name: 'User',
  phone: '11999999999',
  password: 'password123',
  password_confirmation: 'password123'
)

puts "✓ Recreated test data"
puts "✓ Tenant: #{tenant.id} (#{tenant.master_code})"
puts "✓ User: #{user.id} (#{user.email})"
