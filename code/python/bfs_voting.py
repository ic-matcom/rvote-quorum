class BfsVoting:
    def __init__(self, vertexs):
        self.n = vertexs
        self.vote = [-1]*self.n
        self.indeg0 = [True]*self.n

    def make_vote(self, x, y):
        self.indeg0[y] = False
        self.vote[x] = y

    def count_votes(self):
        starters = [x for x in range(self.n) if self.indeg0[x]]
        color = [WHITE] * self.n
        count = [0] * self.n

        if starters:
            self.bfs(starters, color, count)

        for v in range(self.n):
            if not color[v]:  
                self.bfs([v], color, count)

        return count
        
        
    def bfs(self, starters, color, count):
        queue = starters[:]
        for u in queue:
            color[u] = GRAY

        for u in queue:
            v = self.vote[u]
            if v != -1:
                if not color[v]:
                    color[v] = GRAY
                    count[v] += count[u] + 1
                    queue.append(v)
                elif color[v] == GRAY:
                    count[v] += count[u] + 1
                elif color[v] == BLACK:
                    self.cycle_found(v, count)
            
            color[u] = BLACK


    def cycle_found(self, u, count):
        cycle = [u]
        v = self.vote[u]
        while v != u:
            cycle.append(v)
            v = self.vote[v]

        self.notify_cycle(cycle, count)


    def notify_cycle(self, cycle, count):
        m = max((count[u] for u in cycle))
        for u in cycle:
            count[u] = m


WHITE, GRAY, BLACK = range(3)

