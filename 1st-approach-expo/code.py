def make_vote(x, y):
    indeg0[y] = False
    vote[x] = y


def count_votes():
    starters = [x for x in range(n) if indeg0[x]]
    color = [WHITE] * n
    count = [0] * n

    if starters:
        bfs(starters, color, count)

    for v in range(n):
        if not color[v]:  
            bfs([v], color, count)

    return count
    
    
def init(vertexs):
    global vote, n, indeg0
    n = vertexs
    vote = [-1]*n
    indeg0 = [True]*n


def bfs(starters, color, count):
    queue = starters[:]
    for u in queue:
        color[u] = GRAY

    for u in queue:
        v = vote[u]
        if v != -1:
            if not color[v]:
                color[v] = GRAY
                count[v] += count[u] + 1
                queue.append(v)
            elif color[v] == GRAY:
                count[v] += count[u] + 1
            elif color[v] == BLACK:
                cycle_found(v, count)
        
        color[u] = BLACK


def cycle_found(u, count):
    cycle = [u]
    v = vote[u]
    while v != u:
        cycle.append(v)
        v = vote[v]

    notify_cycle(cycle, count)


def notify_cycle(cycle, count):
    m = max((count[u] for u in cycle))
    for u in cycle:
        count[u] = m


WHITE, GRAY, BLACK = range(3)


if __name__ == '__main__':
    init(5)
    make_vote(0, 1)
    make_vote(1, 2)
    make_vote(2, 3)
    make_vote(4, 2)
    # make_vote(3, 1)
    
    print(count_votes())