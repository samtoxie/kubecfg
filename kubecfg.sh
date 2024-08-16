kubecfg() {
    local -A NAMESPACES=(
        ["namespace-a"]="venator acclamator"
        ["namespace-b"]="mandalore dagobah"
    )

    local NEW_KUBECONFIG=""

    local DEST="$PWD/.kubecfg"

    for NAMESPACE in "${(@k)NAMESPACES}"; do
        local SHOOTS=("${(@s/ /)NAMESPACES[$NAMESPACE]}")

        export KUBECONFIG=$DEST/service/${NAMESPACE}.yaml

        for SHOOT in "${SHOOTS[@]}"; do
            echo "Processing Namespace: $NAMESPACE, Shoot: $SHOOT"
            # Generate kubeconfig
            kubectl create \
                -f <(printf '{"spec":{"expirationSeconds":86400}}') \
                --raw /apis/core.gardener.cloud/v1beta1/namespaces/${NAMESPACE}/shoots/${SHOOT}/adminkubeconfig | \
                jq -r ".status.kubeconfig" | \
                base64 -d > $DEST/kubeconfig-${SHOOT}.yaml

            if [[ -z "$NEW_KUBECONFIG" ]]; then
                NEW_KUBECONFIG="$DEST/kubeconfig-${SHOOT}.yaml"
            else
                NEW_KUBECONFIG="$NEW_KUBECONFIG:$DEST/kubeconfig-${SHOOT}.yaml"
            fi
        done
    done
    
    export KUBECONFIG="$NEW_KUBECONFIG"
    echo "KUBECONFIG set to: $KUBECONFIG"
}
