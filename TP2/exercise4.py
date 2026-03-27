import itertools
from typing import Iterable


Attribute = str
AttrSet = set[Attribute]
Dependency = tuple[AttrSet, AttrSet]


def _to_frozenset_set(items: Iterable[AttrSet]) -> set[frozenset[str]]:
    return {frozenset(x) for x in items}


def _normalize_fd(alpha: AttrSet, beta: AttrSet) -> tuple[frozenset[str], frozenset[str]]:
    return frozenset(alpha), frozenset(beta)


def print_dependencies(F: list[Dependency]) -> None:
    for alpha, beta in F:
        print("\t", alpha, "-->", beta)


def print_relations(T: list[AttrSet]) -> None:
    for R in T:
        print("\t", R)


def power_set(inputset: AttrSet, include_empty: bool = False) -> list[AttrSet]:
    result: list[AttrSet] = []
    start = 0 if include_empty else 1
    for r in range(start, len(inputset) + 1):
        result.extend(map(set, itertools.combinations(inputset, r)))
    return result


def closure_of_attributes(F: list[Dependency], K: AttrSet) -> AttrSet:
    closure = set(K)
    changed = True
    while changed:
        changed = False
        for alpha, beta in F:
            if alpha.issubset(closure) and not beta.issubset(closure):
                closure.update(beta)
                changed = True
    return closure


def closure_of_fds(F: list[Dependency]) -> list[Dependency]:
    all_attrs: AttrSet = set()
    for alpha, beta in F:
        all_attrs.update(alpha)
        all_attrs.update(beta)

    fd_plus: set[tuple[frozenset[str], frozenset[str]]] = set()
    for alpha in power_set(all_attrs, include_empty=True):
        alpha_closure = closure_of_attributes(F, alpha)
        for attr in alpha_closure - alpha:
            fd_plus.add(_normalize_fd(alpha, {attr}))

    return [(set(a), set(b)) for a, b in sorted(fd_plus, key=lambda x: (len(x[0]), sorted(x[0]), sorted(x[1])))]


def implies(F: list[Dependency], alpha: AttrSet, beta: AttrSet) -> bool:
    return beta.issubset(closure_of_attributes(F, alpha))


def is_superkey(F: list[Dependency], R: AttrSet, K: AttrSet) -> bool:
    return R.issubset(closure_of_attributes(F, K))


def is_candidate_key(F: list[Dependency], R: AttrSet, K: AttrSet) -> bool:
    if not is_superkey(F, R, K):
        return False
    for attr in list(K):
        if is_superkey(F, R, K - {attr}):
            return False
    return True


def all_superkeys(R: AttrSet, F: list[Dependency]) -> list[AttrSet]:
    superkeys: list[AttrSet] = []
    for subset in power_set(R, include_empty=True):
        if is_superkey(F, R, subset):
            superkeys.append(subset)
    return superkeys


def all_candidate_keys(R: AttrSet, F: list[Dependency]) -> list[AttrSet]:
    candidate_keys: list[AttrSet] = []
    for subset in sorted(power_set(R, include_empty=True), key=len):
        if is_superkey(F, R, subset):
            if not any(key.issubset(subset) for key in candidate_keys):
                candidate_keys.append(subset)
    return candidate_keys


def one_candidate_key(R: AttrSet, F: list[Dependency]) -> AttrSet:
    keys = all_candidate_keys(R, F)
    return keys[0] if keys else set()


def _projected_singleton_fds(R: AttrSet, F: list[Dependency]) -> list[Dependency]:
    projected: set[tuple[frozenset[str], frozenset[str]]] = set()
    for alpha in power_set(R, include_empty=True):
        alpha_closure = closure_of_attributes(F, alpha) & R
        for attr in alpha_closure - alpha:
            projected.add(_normalize_fd(alpha, {attr}))
    return [(set(a), set(b)) for a, b in projected]


def is_bcnf_relation(R: AttrSet, F: list[Dependency]) -> bool:
    for alpha, beta in _projected_singleton_fds(R, F):
        if beta.issubset(alpha):
            continue
        if not is_superkey(F, R, alpha):
            return False
    return True


def is_bcnf_schema(T: list[AttrSet], F: list[Dependency]) -> bool:
    return all(is_bcnf_relation(R, F) for R in T)


def bcnf_decompose(T: list[AttrSet], F: list[Dependency]) -> list[AttrSet]:
    relations = [set(r) for r in T]

    changed = True
    while changed:
        changed = False
        for i, R in enumerate(relations):
            violating_fd = None
            for alpha, beta in _projected_singleton_fds(R, F):
                if beta.issubset(alpha):
                    continue
                if not is_superkey(F, R, alpha):
                    violating_fd = (alpha, beta)
                    break

            if violating_fd is None:
                continue

            alpha, beta = violating_fd
            r1 = alpha | beta
            r2 = R - (beta - alpha)

            relations.pop(i)
            relations.append(r1)
            relations.append(r2)
            changed = True
            break

    unique_relations = _to_frozenset_set(relations)
    return [set(r) for r in sorted(unique_relations, key=lambda x: (len(x), sorted(x)))]


if __name__ == "__main__":
    myrelations = [
        {"A", "B", "C", "G", "H", "I"},
        {"X", "Y"},
    ]

    mydependencies: list[Dependency] = [
        ({"A"}, {"B"}),       # A -> B
        ({"A"}, {"C"}),       # A -> C
        ({"C", "G"}, {"H"}),  # CG -> H
        ({"C", "G"}, {"I"}),  # CG -> I
        ({"B"}, {"H"}),       # B -> H
    ]

    print("Dependencies:")
    print_dependencies(mydependencies)

    print("\nRelations:")
    print_relations(myrelations)

    print("\nPower set of {'A', 'B', 'C'}:")
    print(power_set({"A", "B", "C"}))

    print("\nClosure of {'A', 'G'}:")
    print(closure_of_attributes(mydependencies, {"A", "G"}))

    R = {"A", "B", "C", "G", "H", "I"}
    print("\nOne candidate key:")
    print(one_candidate_key(R, mydependencies))

    print("\nAll candidate keys:")
    print(all_candidate_keys(R, mydependencies))

    print("\nIs relation in BCNF?")
    print(is_bcnf_relation(R, mydependencies))

    print("\nBCNF decomposition:")
    print(bcnf_decompose([R], mydependencies))
