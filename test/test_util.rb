# stdlib
require 'uri'

# test only
require "minitest/autorun"

# relative
require './util.rb'


# just tryin out some ruby test stuff
class TestMisc < Minitest::Test
  def test_get_uuid_regardless_of_extension
    assert_equal "zn004dydpwrz", get_incident_uuid(URI("https://status.foobar.com/incidents/zn004dydpwrz"))
    assert_equal "zn004dydpwrz", get_incident_uuid(URI("https://status.foobar.com/incidents/zn004dydpwrz.json"))
  end

  def test_get_uuid_regardless_of_verbose_path
    assert_equal "8413l89y1n2j", get_incident_uuid(URI("https://status.foobar.com/incidents/8413l89y1n2j"))
    assert_equal "8413l89y1n2j", get_incident_uuid(URI("/incidents/8413l89y1n2j"))
  end

  def test_datetime_or_nil
    assert_nil datetime_or_nil(nil)
    assert_equal "2016-09-08T09:35:23-04:00", datetime_or_nil("2016-09-08T09:35:23.791-04:00").to_s
  end
end
