import unittest

from bfs_voting import BfsVoting


class BfsVotingTests(unittest.TestCase):
    def test_simple_case(self):
        voting = BfsVoting(5)
        voting.make_vote(0, 1)  
        voting.make_vote(1, 2)
        voting.make_vote(2, 3)
        voting.make_vote(4, 2)
        # make_vote(3, 1)

        # 0 -> 1 -> 2 -> 3
        #          /
        #      4 ->
        
        self.assertEqual([0, 1, 3, 4, 0], voting.count_votes())

    def test_simple_cycle(self):
        voting = BfsVoting(5)
        voting.make_vote(0, 1)  
        voting.make_vote(1, 2)
        voting.make_vote(2, 3)
        voting.make_vote(4, 2)
        voting.make_vote(3, 1)

        #        -----<-
        #       /       \ 
        # 0 -> 1 -> 2 -> 3
        #          /
        #      4 ->
        
        self.assertEqual([0, 4, 4, 4, 0], voting.count_votes())

    def test_long_branch(self):
        voting = BfsVoting(6)
        voting.make_vote(1, 2)
        voting.make_vote(2, 3)
        voting.make_vote(3, 4)
        voting.make_vote(4, 5)
        voting.make_vote(0, 4)

        # 1 -> 2 -> 3 -> 4 -> 5
        #               /
        #           0 ->

        # @audit NOTE cycle found when there's not a cycle: 4 is black when 3 is gray.
        # Memory exceeded when retrieving fake cycle.
        # self.assertEqual([0, 0, 1, 2, 4, 5], voting.count_votes()) 
        self.assertTrue(False)