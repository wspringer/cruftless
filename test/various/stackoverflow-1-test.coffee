{ parse, element, attr, text } = require('cruftless')()

###
   @see https://stackoverflow.com/questions/52281389/convert-xml-to-json-with-nodejs
###
describe 'question 52281389', =>
  it 'should allow you to extract json', =>
    template = parse('''
<TestScenario>
  <TestSuite name="{{name}}"><!--suites|array-->
    <TestCaseName name="{{name}}">{{data}}</TestCaseName><!--cases|array-->
  </TestSuite>
</TestScenario>'''.trim())
    extracted = template.fromXML('''
    <?xml version="1.0" encoding="UTF-8"?>
<TestScenario>
   <TestSuite name="TS_EdgeHome">
      <TestCaseName name="tc_Login">dt_EdgeCaseHome,dt_EdgeCaseRoute</TestCaseName>
      <TestCaseName name="tc_Logout">dt_EdgeCaseRoute</TestCaseName>
   </TestSuite>
   <TestSuite name="TS_EdgePanel">
      <TestCaseName name="tc_AddContract">dt_EdgeCaseHome,dt_EdgeCaseSpectrum</TestCaseName>
   </TestSuite>
      <TestSuite name="TS_EdgeRoute">
      <TestCaseName name="tc_VerifyContract">dt_EdgeCaseRoute</TestCaseName>
      <TestCaseName name="tc_Payment">dt_EdgeCaseRoute</TestCaseName>
   </TestSuite>
   <TestSuite name="TS_EdgeSpectrum">
      <TestCaseName name="tc_ClientFeedback">dt_EdgeCaseSpectrum</TestCaseName>
   </TestSuite>
</TestScenario>
    '''.trim())
    expect(extracted).toEqual( {
      suites: [
        { name: 'tc_Logout', data: 'dt_EdgeCaseRoute' },
        {
          name: 'tc_AddContract',
          data: 'dt_EdgeCaseHome,dt_EdgeCaseSpectrum'
        },
        { name: 'tc_Payment', data: 'dt_EdgeCaseRoute' },
        { name: 'tc_ClientFeedback', data: 'dt_EdgeCaseSpectrum' }
      ]
    })

