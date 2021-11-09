// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SubscriptionContract is Ownable, ReentrancyGuard {
    // increment用のパッケージを指定
    using Counters for Counters.Counter;
    Counters.Counter private _subscribeIds;

    // 登録用
    struct Subscription {
        address payable subscriber;
        uint256 start;
        uint256 nextPay;
        bool status;
    }

    mapping(address => mapping(uint256 => Subscription)) subscriptions;

    // サブスク作る側
    struct Plans {
        address payable merchant;
        address token;
        uint256 amount;
        uint256 frequency;
    }

    mapping(uint256 => Plans) plans;

    // // Subscribeが作成されたときに発火
    // event CreateSubscribe (
    //     address indexed merchant,
    //     address indexed token,
    //     uint256 amount,
    //     uint256 frequency,
    //     uint indexed subscrId
    // );

    // // 登録解除時に発火
    // event UnSubscribe (
    //     address subscriber,
    //     uint256 unSubscribeDate
    // );

    // // Subscriptionの実行時に発火
    // event SubscriptionExecuted (
    //     address subscriber,
    //     uint256 amount,
    //     address token,
    //     bool status,
    //     uint executeDate
    // );

    constructor() {}

    bool constant STATUS_ACTIVE = true;
    bool constant STATUS_CANCEL = false;

    // Subscription用のplanを作成
    function createPlans(
        address token,
        uint256 amount,
        uint256 frequency
    ) public payable nonReentrant {
        require(token != address(0), "address can not be null");
        require(amount > 0, "missing an amount");
        require(frequency > 0, "missing an frequency");

        // increment subscribe id
        _subscribeIds.increment();
        uint256 subscrId = _subscribeIds.current();

        plans[subscrId] = Plans(payable(msg.sender), token, amount, frequency);
    }

    // Plansをidで取得
    function getPlans(uint256 subscriptionId)
        public
        view
        returns (Plans memory)
    {
        return plans[subscriptionId];
    }

    // TODO: 自分のSubscriptionをid毎に取得
    function getSubscriptionList(uint256 subscriptionId)
        public
        view
        returns (Subscription memory)
    {
        return subscriptions[msg.sender][subscriptionId];
    }

    // Subscriptionを実行(初回支払い)
    function executeSubscription(uint256 subscriptionId) public {
        // ストレージに一旦保存
        Plans storage plan = plans[subscriptionId];

        require(plan.merchant != address(0), "does not exist");

        // 送金するトークンのアドレスを取得しておく
        IERC20 token = IERC20(plan.token);

        // tokenを送金
        token.transferFrom(msg.sender, plan.merchant, plan.amount);

        subscriptions[msg.sender][subscriptionId] = Subscription(
            payable(msg.sender),
            block.timestamp,
            block.timestamp + plan.frequency,
            STATUS_ACTIVE
        );
    }

    // 定額支払い
    function paymentSubscription(uint256 subscriptionId) public {
        // ストレージに一旦保存
        Subscription storage subscription = subscriptions[msg.sender][
            subscriptionId
        ];
        Plans storage plan = plans[subscriptionId];

        // Statusがactiveの時にだけ実行
        require(subscription.status == STATUS_ACTIVE, "status is not active");

        require(subscription.subscriber != address(0), "does not exist");

        // 今のタイムスタンプがstartの値とfrequencyの値を足した期間を超えていたらstartを現在の値にして更新する
        require(block.timestamp > subscription.nextPay, "still in the period");

        // 送金するトークンのアドレスを取得しておく
        IERC20 token = IERC20(plan.token);

        // tokenを送金
        token.transferFrom(msg.sender, plan.merchant, plan.amount);

        subscription.nextPay = subscription.nextPay + plan.frequency;

        // 新しい値をセット(これはいらない??)
        // subscriptions[subscriptionId] = subscription;
    }

    // 購読解除
    function unSubscription(uint256 subscriptionId) public {
        // ストレージに一旦保存
        Subscription storage subscription = subscriptions[msg.sender][
            subscriptionId
        ];

        // subscriberが存在するかチェック
        require(subscription.subscriber != address(0), "does not exist");

        // idに紐づくsubscriptionを削除
        delete subscriptions[msg.sender][subscriptionId];
    }

    // Self Destruct
    function sendAllMoney(address payable dest_addr) public onlyOwner {
        selfdestruct(dest_addr);
    }
}
