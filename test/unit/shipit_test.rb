require 'test_helper'

module Shipit
  class ShipitTest < ActiveSupport::TestCase
    setup do
      Shipit.instance_variables.each(&Shipit.method(:remove_instance_variable))
    end

    test ".github_domain defaults to github.com" do
      assert_equal 'github.com', Shipit.github_domain
    end

    test ".github_domain can be overriden" do
      Rails.application.secrets.stubs(:github_domain).returns('github.example.com')
      assert_equal 'github.example.com', Shipit.github_domain
    end

    test ".github_enterprise? returns false if github_domain is not overriden" do
      refute Shipit.github_enterprise?
    end

    test ".github_enterprise? returns true if github_domain is overriden" do
      Rails.application.secrets.stubs(:github_domain).returns('github.example.com')
      assert Shipit.github_enterprise?
    end

    test ".github_url returns the HTTPS url to the github installation" do
      Rails.application.secrets.stubs(:github_domain).returns('github.example.com')
      assert_equal 'https://github.example.com', Shipit.github_url
      assert_equal 'https://github.example.com/foo/bar', Shipit.github_url('/foo/bar')
      assert_equal 'https://github.example.com/foo/bar', Shipit.github_url('foo/bar')
    end

    test ".github_api_endpoint returns nil if github_domain is not overriden" do
      assert_nil Shipit.github_api_endpoint
    end

    test ".github_api_endpoint returns Enterprise endpoint if github_domain is overriden" do
      Rails.application.secrets.stubs(:github_domain).returns('github.example.com')
      assert_equal 'https://github.example.com/api/v3/', Shipit.github_api_endpoint
    end

    test ".github_oauth_options returns an empty hash if not enterprise" do
      refute Shipit.github_enterprise?
      assert_equal({}, Shipit.github_oauth_options)
    end

    test ".github_teams returns an empty array if there's no team" do
      assert_equal([], Shipit.github_teams)
    end

    test ".github_teams returns the team key as an array" do
      Rails.application.secrets.stubs(:github_oauth).returns('team' => 'shopify/developers')
      assert_equal(['shopify/developers'], Shipit.github_teams.map(&:handle))
    end

    test ".github_teams merges the teams and team keys in a single array" do
      Rails.application.secrets.stubs(:github_oauth).returns(
        'team' => 'shopify/developers',
        'teams' => ['shopify/developers', 'cyclimse/cooks'],
      )
      assert_equal(['cyclimse/cooks', 'shopify/developers'], Shipit.github_teams.map(&:handle))
    end
  end
end
