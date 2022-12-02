module.exports.set100VotersTestCase = async function (votingSystem) {
    await setGroupOfVotersInTreeForm(votingSystem);
    await setCycleOf4With27IncomingVotes(votingSystem);
    await setCycleOf16With15IncomingVotes(votingSystem);
    return votingSystem;
}

async function setGroupOfVotersInTreeForm(votingSystem) {
    const leftChild = getNewFreeVoter();
    const rightChild = getNewFreeVoter();
    await setVotersForCandidate(14, leftChild, votingSystem);
    await setVotersForCandidate(14, rightChild, votingSystem);

    const parent = specialVotersOf100VotersTestCase.MAX_TIED_IN_TREE_VOTER;
    await votingSystem.voteFromVoterIdToVoterId(leftChild, parent);
    await votingSystem.voteFromVoterIdToVoterId(rightChild, parent);
}

async function setVotersForCandidate(votersAmount, candidate, votingSystem) {
    for (let i = 0; i < votersAmount; i++) {
        let voter = getNewFreeVoter();
        await votingSystem.voteFromVoterIdToVoterId(voter, candidate);
    }
}

function getNewFreeVoter() {
    let nextCall = freeVoterGenerator.next();
    var assert = require("assert");
    let thereIsANewFreeVoter = !nextCall.done || typeof foo !== "undefined";
    assert(thereIsANewFreeVoter, "no more free voters");
    return nextCall.value;
}

const freeVoterGenerator = getFreeVoters();

function* getFreeVoters() {
    const MAX_VOTERS_AMOUNT = 100;
    let takenVoters = Object.values(specialVotersOf100VotersTestCase);
    for (let voter = 0; voter < MAX_VOTERS_AMOUNT; voter++) {
        if (!takenVoters.includes(voter)) {
            yield voter;
        }
    }
}

const specialVotersOf100VotersTestCase = {
    MAX_TIED_IN_TREE_VOTER: 30,
    MAX_TIED_IN_CYCLE_OF_4: 60,
    MAX_TIED_IN_CYCLE_OF_16: 76
};

async function setCycleOf4With27IncomingVotes(votingSystem) {
    const firstInCycle = getNewFreeVoter();
    const secondInCycle = getNewFreeVoter();
    const thirdInCycle = getNewFreeVoter();
    const fourthInCycle = specialVotersOf100VotersTestCase.MAX_TIED_IN_CYCLE_OF_4;

    await setVotersForCandidate(27, firstInCycle, votingSystem);
    await setVotesInCycle(
        [firstInCycle, secondInCycle, thirdInCycle, fourthInCycle], 
        votingSystem
    );
}

async function setVotesInCycle(cycle, votingSystem) {
    for (let currentIdx = 0; currentIdx < cycle.length; currentIdx++) {
        let nextInCycleIdx = (currentIdx + 1) % cycle.length;
        await votingSystem.voteFromVoterIdToVoterId(cycle[currentIdx], cycle[nextInCycleIdx]);
    }
}

async function setCycleOf16With15IncomingVotes(votingSystem) {
    const VOTERS_IN_CYCLE_MINUS_ONE = 15;
    let cycle = getManyNewFreeVoters(VOTERS_IN_CYCLE_MINUS_ONE);
    let lastVoterInCycle = specialVotersOf100VotersTestCase.MAX_TIED_IN_CYCLE_OF_16;
    cycle.push(lastVoterInCycle);
    await setVotesInCycle(cycle, votingSystem);
    await setIncomingVotersExceptForLastInCycle(cycle, votingSystem);
}

function getManyNewFreeVoters(amount) {
    let voters = [];
    for (let i = 0; i < amount; i++) {
        voters.push(getNewFreeVoter());
    }
    return voters;
}

async function setIncomingVotersExceptForLastInCycle(cycle, votingSystem) {
    for (let i = 0; i < cycle.length - 1; i++) {
        let incomingVoter = getNewFreeVoter();
        let cycleVoter = cycle[i];
        await votingSystem.voteFromVoterIdToVoterId(incomingVoter, cycleVoter);
    }
}

module.exports.get100VotersTestCaseSpecialVoters = function () {
    return specialVotersOf100VotersTestCase;
}

module.exports.MAX_COUNT_100_VOTERS_TEST_CASE = 30;
