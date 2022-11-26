module.exports.getElapsedTimeInMillisecondsAndResultAsync = async (asyncAction) => {
    const startDate = new Date();
    const actionResult = await asyncAction();
    const endDate = new Date();
    return {
        time: endDate.getTime() - startDate.getTime(),
        result: actionResult
    };
}