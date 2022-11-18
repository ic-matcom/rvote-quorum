module.exports.errorTypes = {
    revert            : "Revert",
    outOfGas          : "out of gas",
    invalidJump       : "invalid JUMP",
    invalidOpcode     : "invalid opcode",
    stackOverflow     : "stack overflow",
    stackUnderflow    : "stack underflow",
    staticStateChange : "static state change"
}

module.exports.tryCatch = async function(promise, errorType) {
    try {
        await promise;
        throw null;
    }
    catch (error) {
        assert(error, "Expected an error but did not get one");
        assert(
            error.message.startsWith(PREFIX + errorType), 
            `Expected an error starting with '${PREFIX + errorType}' `
                + `but got '${error.message}' instead`
        );
    }
};

const PREFIX = "Error: "