import tincan from 'tincanjs';

jest.mock('tincanjs');

beforeEach(() => {
    // Set up our document body
    document.body.innerHTML =
        '<div id="javascript_variables" data-project-lti-id="1"></div>' +
        '<input type="text" data-bz-retained="test-id">'
});

test('did thing', () => {
    console.log('heeere');
    const xapi_assignment = require('packs/xapi_assignment');

    xapi_assignment.lrs.queryStatements.mockImplementation(() => {
        cfg.callback('test');
        console.log('here');
    });

    console.log(xapi_assignment.lrs.queryStatements.mock.calls);
    expect(xapi_assignment.lrs.queryStatements.mock.calls.length).toBe(1);
    //expect(document.body.children[1].value).toContain('test value');
});
