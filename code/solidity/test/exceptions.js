module.exports.assertPromiseRaisesErrorMessage = async function(promise, expectedErrorMessage) {
    try {
        await promise;
        throw null;
    } catch (error) {
        assert(error, "Expected an error but did not get one");
        assert(
            error.message.includes(expectedErrorMessage),
            `Expected an error containing message '${expectedErrorMessage}' `
                + `but got '${error.message}' instead.`
        );
    }
};