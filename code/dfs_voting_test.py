import unittest

from dfs_voting import DfsVoting


class BfsVotingTests(unittest.TestCase):
    def test_simple_case(self):
        voting = DfsVoting(5)
        voting.vote(0, 1)  
        voting.vote(1, 2)
        voting.vote(2, 3)
        voting.vote(4, 2)
        # vote(3, 1)

        # 0 -> 1 -> 2 -> 3
        #          /
        #      4 ->
        
        self.assertEqual([0, 1, 3, 4, 0], voting.count_votes())

    def test_simple_cycle(self):
        voting = DfsVoting(5)
        voting.vote(0, 1)  
        voting.vote(1, 2)
        voting.vote(2, 3)
        voting.vote(4, 2)
        voting.vote(3, 1)

        #        -----<-
        #       /       \ 
        # 0 -> 1 -> 2 -> 3
        #          /
        #      4 ->
        
        self.assertEqual([0, 4, 4, 4, 0], voting.count_votes())

    def test_long_branch(self):
        voting = DfsVoting(6)
        voting.vote(1, 2)
        voting.vote(2, 3)
        voting.vote(3, 4)
        voting.vote(4, 5)
        voting.vote(0, 4)

        # 1 -> 2 -> 3 -> 4 -> 5
        #               /
        #           0 ->

        self.assertEqual([0, 0, 1, 2, 4, 5], voting.count_votes())

    def test_2_vertices_cycle(self):
        voting = DfsVoting(3)
        voting.vote(1, 2)
        voting.vote(2, 1)
        voting.vote(0, 2)

        # 1 -> 2 <- 0
        #  \   /
        #   -<-

        self.assertEqual([0, 2, 2], voting.count_votes())

    def test_2_cycles(self):
        voting = DfsVoting(13)
        voting.vote(0, 2)
        voting.vote(2, 12)
        voting.vote(12, 10)
        voting.vote(10, 11)
        voting.vote(11, 4)
        voting.vote(4, 8)
        voting.vote(8, 10)
        voting.vote(6, 4)
        voting.vote(9, 6)
        voting.vote(5, 6)
        voting.vote(3, 7)
        voting.vote(7, 1)
        voting.vote(1, 7)

        # 10 <- 12 <- 2 <- 0
        # | \
        # |  11                     1 <-> 7 <- 3
        # ^   |
        # |   v
        # 8 <-4 <- 6 <- 9
        #           \
        #            -<- 5

        #                 0  1  2  3  4  5  6  7  8  9 10 11 12
        self.assertEqual([0, 2, 1, 0, 9, 0, 2, 2, 9, 0, 9, 9, 2], voting.count_votes())

    # @todo TODO calling twice to count_votes()


if __name__ == '__main__':
    unittest.main()
