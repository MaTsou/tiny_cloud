# frozen_string_literal: true

require_relative 'test_helper'
require_relative '../lib/tiny_cloud/tiny_url'

URL_ORG_ONLY = 'http://localhost:2300'
URL_FULL_ORG = 'https://s3.pub1.infomaniak.cloud'
URL_FULL_PATH = '/object/he.jpg'
URL_FULL_QUERY = 'a=b&c=de'
URL_FULL = "#{URL_FULL_ORG}#{URL_FULL_PATH}?#{URL_FULL_QUERY}".freeze

describe TinyCloud::TinyUrl do
  before do
    @url_org_only = TinyCloud::TinyUrl.new URL_ORG_ONLY
    @url_full = TinyCloud::TinyUrl.new URL_FULL
  end

  it 'correctly returns url' do
    _(@url_org_only.to_s).must_equal URL_ORG_ONLY
    _(@url_full.to_s).must_equal URL_FULL
  end

  it 'correctly add to path' do
    @url_full.add_to_path 'hello', 'hallo', '/me.you//andme/'
    expected = <<~URL.delete("\n")
      #{URL_FULL_ORG}
      #{URL_FULL_PATH}/hello/hallo/me.you/andme
      ?#{URL_FULL_QUERY}
    URL

    _(@url_full.to_s).must_equal expected
  end

  it 'correctly add to query' do
    added = { a: 'c', aa: 'b and me' }
    @url_org_only.add_to_query(**added)
    @url_full.add_to_query(**added)

    org_only_encoded_query = URI.encode_www_form(**added)
    url_encoded_query = URI.encode_www_form({ a: 'b', c: 'de' }.merge(added))

    expected_org_only = "#{URL_ORG_ONLY}?#{org_only_encoded_query}"
    expected_full = "#{URL_FULL_ORG}#{URL_FULL_PATH}?#{url_encoded_query}"

    _(@url_org_only.to_s).must_equal expected_org_only
    _(@url_full.to_s).must_equal expected_full
  end
end
