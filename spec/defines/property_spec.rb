require 'spec_helper'

describe 'mesos::property' do
  let(:title) { 'some-property' }
  let(:directory) { '/tmp/mesos-conf' }

  let(:params) {{
    :value   => 'foo',
    :dir     => directory,
    :service => '',
  }}

  it 'should create a property file' do
      should contain_file(
        "#{directory}/#{title}"
      ).with_content(/^foo$/).with({
      'ensure'  => 'present',
      })
  end

  context 'with an empty string value' do
    let(:params) {{
      :value   => '',
      :dir     => directory,
      :service => '',
    }}

    it 'should contain a property file' do
        should contain_file(
          "#{directory}/#{title}"
        ).with({
        'ensure'  => 'absent',
        })
    end
  end

  context 'with an empty array value' do
    let(:params) {{
      :value   => [],
      :dir     => directory,
      :service => '',
    }}

    it 'should contain a property file' do
        should contain_file(
          "#{directory}/#{title}"
        ).with({
        'ensure'  => 'absent',
        })
    end
  end
end