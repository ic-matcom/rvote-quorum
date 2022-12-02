const RepresentativeVoting = artifacts.require("RepresentativeVoting");
const timeUtils = require("../lib/time_utils");

module.exports = async function(callback) {
    const votingSystem = await RepresentativeVoting.deployed();
    const { time, result } = await timeUtils.getElapsedTimeInMillisecondsAndResultAsync(
        async () => await votingSystem.getWinnerId()
    );
    console.log(`${time}ms elapsed to get winner ID ${result}`);

    return callback();
}